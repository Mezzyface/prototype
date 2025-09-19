# Use lightweight nginx alpine image
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/game.conf

# Copy game files
COPY web/ /usr/share/nginx/html/

# Ensure proper permissions
RUN chmod -R 755 /usr/share/nginx/html

# Expose ports
EXPOSE 80 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]